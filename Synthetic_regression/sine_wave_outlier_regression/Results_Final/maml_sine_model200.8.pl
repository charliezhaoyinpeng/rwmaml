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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2327383815488qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2326743535408qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2326743535504qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2326743536080q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2326743530032q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2326743530128q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2326743530032qX   2326743530128qX   2326743535408qX   2326743535504qX   2326743536080qX   2327383815488qe.(       �飽�f�=��>\x[���4=,=���4� n�?�5�k����U�<COǾ�R/?>~Q��
?�Խ<��?#W8>�������|\1�v;���@�>�fC?�Η�RW�=O�w��+ͼ��e��{��XS�?'#�l��< �<��>���J>�i�w�*�       ;���(       k`��!!��M��>v�>i3�3�?��	>ܡ���<�Y���<�?0B�=�.?6� ��E�<@���y,e��SV>� ʾ9��=��۾��Z�9|�>��>5��>4�����>����7��$<?I$�U^4>#)ӿ�z8�w�?~L==s�ܿS���1~��C���@      ��	>`���7!�X1�̟�=�����ƽ3�	�3{ɽ��<�P�y�B��F
&;�S<½�=~[�=������.��/F�z&P���'��м�4�:��=��<�AM="=�X=�#|�K9X��i3=6R�_.�� l��pɽJ�ڽg���A>.Ÿ��B���=�D�=,����~����=�!�Ҽ:� ��<fd��a�Fx۽K`i>��1��e��
{=Tˣ=T�r=�φ���>�tC�7Hl���¼1��>� �=���&G�=Ҏ��G<]8=x�=Sp���k4>~�������	Y���i���� b;�k>�vI��i>ls�=���:Z-�<�H=�潄
G>��3����<����h���Z�ļ��
���w�����=-i�;��?�>S�=0�`��׵�?��^��%��e\>�&پK�?��@?Pi>��=��>���>�h�=�n)?��ھ=��>x"��Խ�K
?��D�X�ɽ��>�F>�=�4?*?�u��P������>.�Z<��?)��=��:=U|�<	�S���q��/;�B	�>)�<�ݽ�=OҮ>'4>�����@��.>�1��6���5̼\Ͽ��7�r#>���p��Q�HjY�eG�?��ɽ'�Ͼ!�޾����N&�L��+ǻ�C$I�?K>��P���.J���?����NY�t�[���S���,����>V�����>\��M��ɤw?�@>�gؽ�Ő�뙋�����^[���>����g�=�����:��?FUݾ?����m�W`i�(��|g2��<8�>>�>�=:GŽ:�6>��C��M�=�w�s��Mu㾌�[>�[��/������)��<	W������=p3z��\��>*iD>גƽY�1�0YE?�@5?.1��}ƾ��>�@��D���U��T�<?:+׽��.��;o�?��>�$�Oy��g]<�#�M�D>C��ۇ��և�޽��>�\�=SFJ��1׾��=�<���9�;a�>_�>i7?�	�=�>�"���T���>2>��&�y�x�"��n�Ȁ�>�׉���>>����^*Z=�	<? K�"��C����Wr?wB�����=s��J=�2������i=����X���S2��������������\=41ּ��|H�<���f�
��;���c=G�C=�|ڽB�7��;bi��0�8�,�X����ڼ�'�� �߼t�Z=�M��5
�mw�=�0�><�r >��=��=G��]o=?��?0}�?������?,�%�UGʾD�V��*��(�?���>�f;?o����V���B׿G�p�9ZX��7�E]
��t��&ƿ��>�2?�%ֿ�d�?*{��ܾk���[����B��]�+��og��(0���㿧��>��1�p����䂿�d7����$�ɿ������5����ٻ��⻒���ھO.��9���f��4�����;�i���#�>��/?t��޹�=������=� �?�Ҩ���I=��E��ݧk��o��P?�f��V?ul�����J	@��ξd��C�"�mG@>��k�ҎC�!����"W�R/���r���I����>T���x<#��	H�>�<�=ekҾ+�����+�}�8��J}�V���,Z�_�d�}�>��{?���:��>ISC��7�O�?;_^>�m">��m=sM������5��	�U?f~��@[�=\����c\�>���=�����)9����^�_=���rS��a��=c+���;/�=E����D�2��<js�=�O���<�3��~R�������=�O�Am��h�+�g}=_��F��=��=M������Ƚ!��=?��=θ��͇�I7=dBX=�Wd�N�aFȾ
&ɼ�3>�}z���n=�@<.&>�Ϋ=ࡾa�|=��D>؝��L9��^��k�=�T����=^!?ؕ>��g>��<���<kS��_�>���m�ʾa����釾l��bm>�X���&�>�;¿��,>�?��ͻ<~
��5�=�T?����o��$�=wl�>�fr��~����>�C�E���{���!<ܯ�w���d�]=l��;�r�=3����Gk?��>�s�=a���`� =v��1�>��־4]2��r�&7W?�B�>�Z�>���>��?�9�a��<g��>-����{O�+�U?g��>)��O�H�8D־��#��Ux��#+���ݼv��=X+Ƽ�W��3
���<c��B��T�K��]ɾǼ���>��S/?��?���=H�=z}�=b��<��<-=;�WM�bs3��iD�-?L��h�>DȾ��"?-#��6<��c�>��H=	���?]� �c0>]��=,�)���߼�p��ᗽ��,�A�ݪ.�k�;I����C��q��~'>��>�IսD�;=���?*��{�^�Nq�=��\<��ɿ-�6<+cZ=�Ӿ�C�=�x���Ѱ��?�����X�?,+>�!����&?�φ?J�����=�oP�?:��W�2=�K=搸�A_�<�3�<;�=� ˽H���D�������;��7�x��a��=�i�8큽��"=���BZ�ܯ�h�=��(=Q!�����|��#5�O���ȡ���I�s���B��=pys=8�"��p=�	9�+�����������ҽ�Y�<l� ?%�+=f����DA�>߾O,Z?�`�<�֠>bd�>a�ľ�>���z⽅�Z���A>�O�>�?�A^?�4?a�м&l>�̈=�=I?��<dn��?����-��N}�>1�����>�����	?#�%>�B�>0���-�>@7���?¸�>ߜԾ{ n��j�:�۾v+�>����&�>`#\?eu콾m?��ѽ}��(Խ��>��?�������ǳ�>���>>�>c�?ΐ�=*�M?��O>�����u翋�;�oD���(Ǿ*2�	<2?�0?>��ѿ\�g?ɵ�? %?�kT���H�3�8?ސ>5W�R��=Fٚ���꼼]�=PI�=ԙ׽�ֽ}�ʼ�@���F�Ze���5�^�<=��}�"YO�җ�����l[:��a=�g��Խ�� &����e�3
�=d�1���x= =�J����;=E�A� ؀�-�A֦��D�Lٷ=�xM���^=b�r�4k=��=s;�4[�>�S����f>���N��<��<6[���4.����<���>I.>y�.=�|>��=�% =� �>�}}�k�����̉�>\���4�ǿ4��V_�fŽ0�J=,�z�V�����D4G>E�d?�䪼U_�d0�g��<ˬ��Ew>QB�=S�>Gj�?ϋY�Pt�>%��>"��>x	k>���=�+\>�w�x�?��}���C=��9>^� >���N��7��=	��>���=~пf�,����=�E;��ʿ?�Z��Y��W�P�~�/s����=� >\91�)&G?m��=�I� �><��B9��� >C�R�U���G��=�P>������^��]�l���\|Y������EW�Ӭ{�ZS����ɽ�	�;�/���"�}�ռO�������&>Z��;�a<A>�9� `
�L3�����#2��Ez��	�&�G��p>��R= �B=d�m>z��(���-?6�%?�͵>�ּ�ZI�?�2�m�'�jT�i�<s�?�g?G���Kl�y����em�[b��U�g��ҏ>k?��c� I~<;.���P�>�C�=�p���\e?u~&?���=z�|��=_N�����e/�=�п>쬽���b^6?E?a)d>ӧݾ"J�z��>��$=�H��>H�pZ��o�)�i�H��>�:�I���w}>k�>��h<�uH��(�?�;��:>܌r�"��=Sd�-�>+Z�!����4�>������,�a��=X�_x?*�Q�&R>��-�,8Ѿ�žY�T�w䇿�����S�D�=��3=[I=^��;`� ���%�^у=���;�L����<��\�&�Լp==o��V�f�B�:���<�6���f���L�'ʓ�����x��
�=_R��z[��.=Y/�E�ۼ�޽g�'�e�j��8=og=BST<E����u>6b��9�` �N=�=��'�¼��:�}=��=�꡾o/�=���X��<pɌ=�������ރ�<!�=�������
ӽ���=<�	�wY �>ٖ����߽^���i��<T�G��.5�H7��+��W�>佟��H�l��~�);���>M-j=���4��=�/A�Z�����������}�,�N�`��j���һn����)�=��>*����Zl��Rv���dp��?�=O��?���=NX:�[��v�2?�O�Dƽ�Z��%P��7W���� E(?Op,�>N?�n#�^vV���?��������{l�R��?(���A���>M�3=�y�=��<��ý�!��a��=�#�=3��=�`^�,�<;c�M�!�Q��>����\UU����=�n��*�����=�	*�뚰=R8�:���F�3]-��"'�P����<ԕ���>��ܽ�\�< ޅ:���=���;jN=����"����>�|?<ޜ<�W�>��B?��5���Խ�����?׷<xl�>i�>+�>�9��l���7��m�=�z�����{���Ɨ=�vV=H#��	�=6��=r�>�O���V?轹ȿ����h9>-�־��得ވ�Y��q�?.74���=��=�	�R����<�3��ڳ�@=���c=��b=��?�f����/=��4�TB+=G�4���A�jX����:�k+?�o�޽�漣3�;�|4��v���=��w=�����=�ٸ��k�;�x����^�Ih�T훽 Cu���� �<�^>$i=ss��yG߾�0?�Y���L�E��!���`�?��U�>�[������nz>̞�>n������W���-�=Y�b��XE>��^�A�X=(0��q�?l�:�QѤ>J�� ƍ�M�=��˾]�����F�꾿�G��9l��>
>ԃ'>`�~=	*��(}G>��:@���N��k�����>��
��ɽ�up��.ٽ��i��eL�U[>��q��>�:!>���jX^>�_�=��q�{>/
<G>��>��>��=����ҏ�꾱���l8��_\���>��׿�!>�*�?W�O�`U�r>M�>M>8a߾�Y�'�>hIQ���<dY#=e�>*e&��'���<o-�����R��({��,�:3�>fa�=P�}�<DH�<�խ�FG�:��= \���T=2_��"��=hG�=B}���߽�,��M+=d_�du��(�����M"�A�(#�=�{= ����iO�uJ>Ґ���&�X/׽1�<<��v�@�R���X��>x�;�]J�+P�<�E���A=�,��L�=Sνz�	�n�=xㇽ!���:T�[�׽�hM�p�=����8g�<`�����8��p�@>½B�,��[��!潭�=����A ��>��/<-l>CA������E�*��Q��O9��bD<�M���8=�p��V)�=�8�=��
�_i�������>�
��p�{E��}g�/�=���L%<hG���=n���P��*d��]X��S����A�f�Z����]t��tG��^Ž�0N��E��Ӽ8��<�@������S����<������c�V�Q҈<��Ľv��>&��D�?d�;�I6�KH�>�ύ=w��$�>�ڟ�s�i<���@�>W����ju���q��u�>/�=������>��1=Mp���ҽ��W<u+`������=v�=�ux?�H!=қ���S�ݖ߽M�;)���,�= .��C�=�E��F�=^��<z�ܽ����-�}̿<�A�H��,�<��t>j�w% >��<)O�<�0�=�G=�� �(�=7�o�
'�A==��\<�Y�9)���l��{�<=0�T?>=�M@�C�L�=��9�2ri���>e�̽ջ˽Y_���f=}�W=��'��*��?��Y����'`��u�=��ɽ^�����=���=���=�;�=xw�>���<aO黎G�� ?�t��E4�F��~�M>���ܓ���׼m];��ۜ=���vM���>�6�=c��Æ����=�L?��>�I���v�m��<�;�k�>��
��'�>yf!��G��_z�P'ʻ�A�=��:��?&;�If9>!8>X���p>�߾�����e�?H��=)��<������>?��хM�l�[���>h�<>tGk��ɳ���?��?(       ��ͽ$���7ꖾ�X�>d!>bs��U
�>���=N>Ywr?���>!�l�x$$?�;��?ޫ�<Ʒ���ͿlӾ~Ud=B��>� G:�����9ھ���=��h<�C�:��s>,��JT�>>�m�nj�>i�?}"7�fm���e<����%H���뾋���(       �0?�U�/�>�dl<��>j��>��f�ۄ�o(�>�o	��		?����iɉ>��>���>0�??p=�~����>��ξ���
���RdP>C֝�|�?"�&��\ ����\씿+_(=��?�=�>G;?s����()?(jD�n]�8�A�