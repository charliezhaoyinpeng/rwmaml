��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.heuristic_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\heuristic_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2841949255456qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2841949254592qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2841949259104qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2841949254880q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2841949259296q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2841949255360q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2841949254592qX   2841949254880qX   2841949255360qX   2841949255456qX   2841949259104qX   2841949259296qe.(        �h�o*�>?��>�=�E��B�
�{ޯ>�YW�r��>p����.?��?9!�?�����S�>x�k?﷕��@,?�D2�?�^>�r1?	�>������h>�:㾕�D>�>�����;�WOD��v�&_x��'Z=�5���z��ڜ��+W�	�����*���u?(       x�&>(��=*�C;�T�=DD���<.��<>z�=8u�=�2�=m�0=�<F�}�G�<75|�����8�Q;�C-��d����	=����P��=�Pҽ@a�=��Hɶ�b���vӈ=�u>w��=�����R^=�Ͷ��(�<�"=h�\o=p��燎�       �5�=(       �����YE���p?�_��[�Zʬ�� �(���dk�f 5?�?t��Ѱ.?sC,��54�ܔ?On
?-I9��/+?�^�>��_���>�Z	�=�[�n�\��q���1b>��H>�Ag?��U?��4?�Y�>:�g?ς�>~���?���=�/n�Wī>n�3?@      /ߡ=�3��8�=1���{�=�Ľ��=�'�<�
��7���K��-�>;�~=f�νB��=HB>�jy�i�c�2S�F"=̥�=S ��Rv����轥��<���#Eý5�l=�>g��-�����B<ɽ}���G���0�@�=H���i|����=>��<�q1�� �\-;�<�J=�/�=�M꽬f*=7��<5Q�:Z5=	"�=��r=�%=��6����=�9+�xD;�>�����<1B�=�տ<������N�T�Z=�wD�4�p��Y�Bp=/��=�G)>�\<�9%=M��H�=�s��7c>n�=><��;���w���k8�l�8;�N�<��s�[��<q��=ݨ��)��޽�S={R�=�iU��r켂�=�>��=�,>�>��.�����6{=�> ��^3ɽ	%�H[=��P�f�=� >�`�=j�7m>t�>���=B4�=�lM=U˹=���`=fc��"Έ=PU����x�@=������?>���=����<�d�e!��pT�<7:e<��=AB�<Џ�=��<���=.�=�X�V�=YO�=S��3>�;>=|+�O��=[�B��  ����=�K�=f�=�R=�=tA彰^A���*>�����n��B�=i�˽�ʸ=X���J����3�=谍��?�j'�=�/==..�$$�=�����$���>� �=�l����<X���7+>�X�=o>����x> ��<܇���#�B\��n�A�(�J=љ���a >(X6��c���= ���C=`�}<���=^��� �<Mp����r��>31�=��=IO
>N*>�g1�^68<����s$���=tS������=��0=�
>A}���[Q=��<%#W<�⽽�>|�M���%�)rA=@N���'>�c�=�Ĉ<\������=�-<�N��h�=\�ʽ�+�=�D�=�>�VؽHӐ<c����}�TڽH��<��i=��}�:B��6���l^�����XNɽ���=�=�=�����\j��4�=ݵ�� ���<j =ƨ���P�8u=�7���1�< +���HA�L�=�n=�<�=-I>rȾ=���<�ѽ,���P)�jk=�ys�h���r��B��=��3�6]Ƚ�<�=-��=Zc��D�m�ҽy��=&Z�=T�=륉��f�cԫ������Ͻ,(�=�pǼHQ=_T�*��=&��<�N�蛂��<$.�=���<,�=@�(���j�	���=%���;�<KϽ¤���):��<z�׽��Խ��/>{x�=3w���ڼu�l��9�Ƽ���=Α����=��=�-R �>=��v;q�=��=��}�L=�.;>m�<�|z��L}=γV� f���9=�Hż�9�y� �H�<��;P3!<h/�\7�0<J=�ҽ?B��2M�$'Y��[�:�S�=j��=2D_��ǽ�c��W�<Z��=��=Xѽ��ʼ6ؿ=Dν�"=߻��h���3�i��������ɽ��<���=��<�R=��ͽ���=�b缢�=��=��^��Z�=m����<ƃv��̸=t�d�#.^�iࡽ���~
�����Q��<O��=�Rw=���o�>�� �=� �<B��=��>�oE=��<���=Z� �ȥ+��b�=ϕ��mΜ=ֈ�=Z�{�~=n�4�%���0/��fi='�=g=̽�i���p�=s�=c��<��'= 頼�����ג=�\"�7v�=2���#�=؃6�z��=!M=�$�/��=����y8�Ŕ<w�Ž럱=o�5�``�=���=��ν�>�ý�t=�,<��>5U�=}�=qf%<�@�� ݼB�<�C=O��V�=D.�s;/��;����P}�r�=��������#�z�='�.>|���&�(��;&I�<�s��g$>-9ֽ�V�=�>F��=(�=�	�=$�*�e@�=W�9��*�=�M&��i���b�R<}��-��=3"=ڮ���Ġ=^H�<i[�=j�'���	��)'��Yq���=�J�<i��=	��hkf<���m3�=�>�"�r|ܽV[�=O������I-�����F7�3\ �3ԭ���=����Z��m�8⽬�8����=�R�����=^0�=��e<(w;=E�'��2��$���@����<X�!�{�>�Y1��ϸ��= ��:8ɘ<�Y7��<Z��	3���<`�e����=bF�n�"�@K3�P�E<?ս��I���p�ܷ�=��"���	�l��=��=xbv=Z�=��0=`�����;@�'��>_��NQ�����j<w���ҷ߽l�ܽb��������
佐A,��>��=t�=�k�=��E=<Q="H� -�<� =�{=`h�<�꼧�]�'�=�	�Ip���߱�r�����I��E��`Z@�aU.=ji#>-!���G<�ý�����E>L��cAݽ���=:��

��c�<��4����<����_�;��>���=���4�#�=�:>q&�`ɽk��=E�u=���f��䶽9��<��5��O8'�t	>�|=z�=C�@>�KA>�����n�5���j~ѽs�,=�=�z8��Z_>�Ž?�L=��t���c=/���p��<d�s� P�=C�	��;սｩZ�=���;fۼ;�ѽ8ٙ=�ɝ���],@>8|U���R=:�<63�= �v��w/=jP>:܀��-���=^+��I�@��=�f�<��Խ#�)�Z�"��A��p��X�=�s�����%-���=t���U�-U	=��=�`�<U�I<���j���ؼ�����WJU�F��=�!�=G���\��25�=�]ٽ�>��L���'�=dq�N�=JX��|��&�켸ڠ��2�P\��O=�~�=��=�M)<S� ��&��:���7��V��5P_��� >@z�g��=H5i=:��~,F>�=���=��B>��Ӽ?>��$>��ȽR�)� OM�ث	>Xk=��?�M?	���q��ߎ=J�=�x�=�[ǽ��=�����Ӭ=ڙ�=�T�	�����g�e���<]��=�1޽-��=۰h=x\��U�,�> I=�Q�����>dA%��~�<�*��Hd���p=u��=�V�=�Z�<����pz=PWb�֩��2>����0<L�߽T��K�� �����=�1>
I���C�=�~=�lýX��<�y߽S�>�Q=Z��=�p�����<`�F<d��п�����=�*� ��:�殼x�F�=�1ٽn��=�"��ㄣ���d�������=�����k�������D��`�8�¤нa��*c�="5�=*���$�=8¤��k��d���㏽�a���ƽh� ��|�=i�<l�ڽ�~�; K�<P4`=������=�F �����M������#	>����v��=h7�=���"��=���vs�=�A��>�>��=LV5���=F�ӽ��w=�A�`9N��s�=�����'��z�$ �= �����������c&>�鹽��F���
>\��=	D�=4T���^	>#3�<���;P�)=s��=���X�>�7��B:�:�>�dG =[ a�jA��3T��%H����=٨�=:Q�=%�=��4��/q=p&>9�=����1>��%>�ӽ�M+>u�=u�����Ӽ4����=1˽�;<�����q�<�T��5���j=a�Z�d�~lV�7�&>�i�=ۑ(�A�'��9��,";���=�ޠ���П;�LG=�������@=�>��ؽֆo�1[��o�=���پ�>����]����=l�=2�=y�=z5=\��
X=�k�4<�=����PP�=
�νo���tͼt�<�#�=c�&�$����&*=қ=F����|�,u�=�	`<[�<��j)���>�;�4D3�|��c�#�_J>�\>ɺ~��K�<�
ͽ���³�� �=�F�;,I=%��<�@Ž��=$�ϼ���!�ͽ4����`�<�蝼�͚=�u�=P����A<��t<�{s�o㟽��=�[6��ͻ�,���-�={M>&�=S;>2T����;�@�=lI�=�'½��=BNz��Ϯ=޺ ���Ἔ�ƽd��=�� >VL�=��(�9x>����*m����`����=~[�nn���~��l�����=��>�>X�i=� � �19@߆��+��P`���=[���`��;v��=l0=�= %�� BD;}�`o�< 7H=�[�=�,�6X�=`��=��ֽ���q��!�=a%<;T���]=_��=i�����U�=�+ͽw��%^X=�ր=��89|=��=<��=��i�
<!�����ڼW�>�g��5��f��=��4>Չ�<	�B>�AP��X>��=�D=P���p�6;lo=J�=c��=����Xw=3�;���=����HE�L	r=F5�`�z<3��<&<��=cٽc2�=p�o=�7�*���t3>Ϯ=Z��=ԗ��U_Q���2��}-���/�~ �=u�ѽ�g�Q��<V>U��=���=�[��mh�A�=��<K�=����a�:�'�1�	��E>���������a�����Ƚ{�n<;�5���=	�{���<u�=z��=�晽���=P��<��x<׃�=�z�=��ּ��=VX=��D�������3<���=R��=�C= ��kI�_����Q���K��kl���5���2���=�!>sU�=8	�<���Ӈ�)��=���� >T�"�뽜���l���RUw<&Q	�&�7)߻4M���4ǽq�H�[�
>�=�Ɣ=����i�=� ��@��=%�=�&=�8�=�7�=�O�}� >��T=Pzx< ,=��<:�
��>��=<s(=����v��=��=��	����.褽'˟�(��������<��=NR>^U2=�A=<^U.>r>Ž�;?�-=ݗ�;-E�<�_��Wп�b�I������nm=1���=�j�=��>aR_�ט�=<4#=����1!�=���=>��)=C�=X��#�ͽ�b����=��>v'>c��w�=�c���<� O=�GG=� >�=�=���=�x���\��� ��n=��O-�=�׽^�ʽj��=2�+����=$R<{]>�K=��|�@�=�I�� '����I�������<Z��=P���Q�< �}=4D6=��4�j�q�Y=���[r
�lu=?�ʽ/�=_W��F�e� >d2��-�=�P*���:�X�i=�"J=(��=6��r�=#Eͽ(w>�&�=�;�=�Ǖ=��<��eϽ'�ν�\<q�i��T;��=fTݽDww�W��=���N^��M���������5=����I��=�ǽ������=�=Po��=Zt�=e�>E >�x�j�=]Oc��v�=���=��89�<i�p���m����N=Avr��
=&�	���1=D���ý'�.�IB��E�V����g>k������<��ѽ��>R�M�����=Bve=��8=^����q<�>���g=��->��Q=��ѽ��;Ѯ�=@�=�*S������ٽ>�m����<&[�=t6�=�������E�ϞD������=(�d=���<г���a=�=��s�ت{�h=?�m�`�;+Z&>�2�������ō=�.��Kc��Ҳ����=hx�����=��="A���=�@>���=�����@t��ԕ���Pǽ������=�V�����<�O=02�<N,ʽ�i��x�� :�;Pg�&�= �O:�[��Z<��>��6B�=��=w	�������<b}�=�I�uT= X(:��ڽi�=<���0��kϽ��=���=���=Z�w�����o���0�!���Y�>�FS>����= �};Y"}=�N潵\D�W脽��W�,������=u�<(��n*��Z~�<���="�̽.����k�=�Ԧ���0=y>�P���ȼo/A�F��=��R=MF佛��=��A>��>>�~W<	[F>e�:M����$'�%�2�Y�<���=Dr�VT�a����<̍���%=y �����2+L�3�>苜=��6��=@c
��>���n�R�����_�~��=̋= D�;sy�I3>H���.���k�=�.�=�&���<f����@Խ.ӭ���V����<��̽� W�XX=a"���>d{l�!5(����S1.;S�
�>V����=��=�>Yڼ<�W�q�C��_C��f�=U�>q?������v=�S+<��s��S����୏<�0>X��=��(       =:�=i!��=?���=��l=8�x��N8�sD�=����@G����
C�=��=l�Ľ(��=jG4= ��=6�=����r�=�e�����<���=����Y��kI>H�<�E>�?r����=hԼK)�=l��W�=�<޽�	�b�����>��y�ۭ&�