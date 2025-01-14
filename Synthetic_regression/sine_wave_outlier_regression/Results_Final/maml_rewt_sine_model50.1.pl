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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2841834758784qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2841834758880qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2841834759360qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2841834755808q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2841834757632q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2841834757728q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2841834755808qX   2841834757632qX   2841834757728qX   2841834758784qX   2841834758880qX   2841834759360qe.(       N�=�YL�;z��8�to
��;��2_�X�<$2�� b�:�h�=�:s=�R�;-+�=����a&P>�C=�b#�U������P��K�=:[��"��̻<����>��J�	>�X=�!/=@�=IĽ:Q�vUF=)�=0r�l�'>/�<Ynb;(       ���O|�G�=��ҽ�Ő�{
a���;�� �^��=�����g>E�>̦m�q�����<->X���F>��ѽ�Ž�
�<�s콶m½(}����C<��W��_R>mk`=��=>�������u>���=S�����=_>��> �I�^��       ��6>(       `�S�n.'?�e���C����D=�΀��du��1���>�??�b?3��=�=P�>��>�'\����>�̀=��I?�Az>au	���$�k)o?ة'�6��p�x�o#�>����1�Iw?�oc=�3	>[�A?�"[>4��~�X��6B��{ <<9�(       ��A��t��A��>3��>�\�>=\�=e�=�@�.�>lt���W�=��<�R%��f?De����彲���� �=�d<?rp]?w2�^^�tf?�
7�  ���	?�'�z�7�{ i�Z^ܾ�\�=s=��QK��7�>Hn?_�>�9�>L?E���@      h=P��j?4�2n<�>;� = c�;�<Zxн�
��Ľ���=%����Ѽ�b��n��_��Ͳ�43�@u�|��"�N��T(�x)=S��Iµ�UXI�Υ��E�>��	�o�=�Ǯ�	j�;,�:�-�=�㼰.��`7�=���=wq�
#>+�i��>S>�'%�M��=������=����̳��H&�lN=(�^=j�<+�� 8�w�ڽp"�����,��{���
��Z�=p���������=>��=t�̽��K�~�>�1��H���Ɛ+�3[=��o�ҽ�;;$ɽ���="_=��k�,��;�>�?���5V����=05�����&:�r��=������{���#>m[j=�3i�{ͽW&>k�= 1����=U%�<Cͽ���@�=���Er�= ? =���8��kK���=��:U��;�r=*�Q=���=߯3>U��=��f�>��=?iX=m��=�$ɽsG�w�*��� ��j��^ݽ!/F��>o9�������;����=��<�C=G�=�5����b=-%Ľ���(�]���%>Y�=F�޼�μ.��=ʖ�<�c�=}�Ͻ��e<�Ra=��=��=���=� >����*��v�>��Φ�=��͟�=x#>韂��%�77��+�>���K�����=�S�=�����O=�={��=hޱ=���;���َ�=C,�=�z<;�=J�ܼn�6��T��Z�� ��=U1����s,���O=VNJ��N�:J���|>H���l/=gW��rS<U���1f=��꽏���h���3=��нD�=��l�~�=�ӻ���L�<�r"Ͻ������=V�(�B��=.2����ͽ�&�=��	�x�;��=@���޽�W�l����ؖ�"^��_/�����b�=qh�=äO=��,�Z@�����=��>r="T���=ۓ ���9��f=v���^��-�C����IN=yV7�.69=s*>�=���=	��=C�)=��=:�7=k=k=�$j=�x;���=�5�=�Ә��n=5�=�C�<hA�a���n�=X�K��⣽j��kp����n=�쎽�]=���K+���=r�4��/O=���=��j=R�=c>��~)�=_��@�c��k�=U��=��=�
�8�=��<���<5n�=���=�7���=��R�-�輁=��ؽ�ټ����[Ľ�ֽm�}�|'���y������ϼ~�=F�<\�}=[�>��=���<z>�P-�<0��= U���/ĽZѷ= �ػ���QŌ��`�v�=�%��e뮽�m��ɽ���;x}?=��什V��/=�Q���Ѽv�����=I��@h
=��T������>��Ǽ~y�����=Kl���������̩i=V\�JE�9YŽ�=b��n\=�j��A�Rx��j��<1n=t��<S��=� ʼ�e$���s��½ ��=y���B=¶ �S(�<�x�<��=:A	=���=P|=Bʬ���=��ɕ��w�U�K�@<�O=��=�=I�&j�=o����!>�0��=�B����ȼ RE��cܻ�Ϟ�|j��m>=���;@�C�b���"��=o�>�T#�Y��d�q=���|�V=�����o9��R�=��(=�=��>x�ݼ�̃=JŸ=��=���C����N95��I=l��'5���9�� ��;0@��@L<;�i�=?u#���½׈!���+��=C,����ͽ��W=Fo�=pl��",���b��×R�V��+Ե��8�=��Ԯ۽��i<w6>r���񶽩��=4��<Ti:׽B�W�8�½�.E�̗{���f���;��߽r��=�ԼU
D<MG>
�3>��#�� żLW�<��齏Ѳ�b�m��=��;mX�=HY�<�5>U�>ٱ:=�޶=�<��H=�5>f���d��򓷼��Q��諒��2=�2;�3!>de���>4=M�P�>��	��ɒ�	������;�>���=������Y�A�+��=�F�r� `�:z?(���=꛽h�Ƚ��=$1�<����i�>��V=���=Ii�� �=�s��|>ܿ��{;�<��Z�W+3��~F=�	>S�}=�p=N5鼕��<R=�Խ�L��t��P�=�̽a�T=�m�=2r=�ݴ�v*�=đټ�����.ռ=�=�L=R0���^�<YC���	=y�׽{�ƽ��ҽ?����H�g!<�*ֽ&$Q��^�=���=��ܽ��=�^��	�[�>�Ϥ�&��!ν�˽�}�K >.�#��f��>2�����-��=��'�����$=hQ�=���?�ҁ�<L��=
�G�Oځ�R�^=&����������<P�����<��>1�μ���3w��-��<�i>G�潷^�=�l	�x�>�QĽ�!U�T�=��=�8����,�C����X;?r/�����1�=\�3��½~gb��3���=�D���K��p��h��=,��$'y=0�½��v��L��=T�3 �<V���꽕��*��=.g���):�?�	� �4ZW�a@�WU�=-ؼ�'>��=�����,=���|�#��4>��>�$��o:�=c�A��>���<T����'��������7�>oO��*->]ߚ=�	�=ia���~	<��>�4��N�}��y�Z��~��=�=�=��d�F@�=���(�B�8?̼��ܻ�$��l`=D?X=����=Ho�<_�=�*�����,6=����z�νXG��X >����������ּ�.=j��=�ZG����=~�=��=������=}%��+�=2n�=����%�<pʗ<(����=X�v=[��R��=��=$�I=@��<�{<����0��< hb;x|=���J��=`=��`C��2i�ߩ>`O���Zv��s���>����̽���;H,-=`�<��d��U����!=8�x�	=�S"=������=W��/'���� ���>�K�=Hߓ<h(�2��=Q��	�"r����<S���>��/=�X>@ ��J��= .�=�L�=�"�=p���>
��y��� �PE8=��=c�� ����� �=�ſ<$B��O��6˫=��|�#>Q����=ő=�;�^��=��?��h&�R�=�=/�5���=�?�=���=K�l��G�=W,�=�$�=�(��=����24=���<e��=���=p|�=��(<�u��P&�Ƒ�=�����^��>���<��=�1�o={�$���"9�x<\�^8�<f��=�)������f��'��=Ru2=�ԙ���#���x&�Iߠ<�N�������Z}���=�h<*A =�TR=��>
�>��g��jļ�;�=�(���r��X=��=���=_�B�7�7���=������4=����`�=3��=��=�/���>��r<�#
� ~Q:g� >��Ӽ5ɼ���V�����!�*J�=$��>��0�l<�0`�o�<	�����O$>h��<���r����������@ <s�½�G�=���;���=� ���^�=�_�wp�fH��z�< �Z��(����0=�'�=��>�G>��>��V=�x�<��&�#��|�=�����@��Z��5N�=�{ӽj����X�=�ŝ=� ȽQ���؋�d+��Mm����&��!ν�V�=������=ŀ�u��;G�2��u�=��� �˽�P��A �Ze#�b��=ʾ�=p�ٽ��[=��h���}�V��=�|�ص= 5��8&�<	4�>��P0��L���J�� D&�>�q���ٽb�/�����29�=�z�k�>��<��i�=�=�W�=���<"a����=�qv<�l=�'F�2�=o�@��p9� q�<Ȋ;w�=a>��c(�*��=���=�C���ؼ����=H����=��G���=[?#=y�ͽ�I��<�'��t��8��vp�;�=�qL=jA�=���<�+� ޹=�ߺ=�Ó;�O�=��1�~�n��==��>ۅ�=�Ef��YG�&U�=Jͽ�岽Mx+��m�G>�a�=��=�9>�+�=�i���=`]'���=��=� ߽,��=eU�����uw���w]<���=��������+�.��=f�q���0J����=�m��3�>Kݝ�<&�=wP<���o�-<y=��V���	=$�r=v�<P>�<k=X�Q;V�=�Ô���=��:� �-�!��нw��=��A=s��^��=_��=Ч}=��$=n,<��7�>sם=3ܒ==���f�=P7��e�ɽ�	1�(5�=2ὣC> ���� �[��=�V�;����>�S=��Ӽ}�=k�D>�T<h��<wݽJ�=�
�=��K���?�����դ�Ȧ/=	���	�e<��Y�>��3�V��=�>b���Ek�l�{�.��=�f���'=mX�;��=����{�=�>��iZ>b3�mEQ�e�>��F��Sၽ���<9]����=p۽Ɛ��۽�>j4�=X9 >B��<���<e`�0�:��2�a�>�b=6j=��>��;���=6e�nG�x[�=F�<Qڝ<�>��C�!�I����3)>9��FA�!���Sנ�8��<�$��3>�/�<�)��>	d�/��<�|�=\2�K�$=-' �u�+���y�΋��݀�����	>?���=p��;�X�==���n\;
���FDY�`j>���<C(="6�<a�?=���=n�׼R\4���=�*x�;'K;�<m�������3��=������=/��z2!=wH9�(%���a�/D=��;�����7��<� 绝���jb=x���q,8���=�b���� =�R >K!6�/�b< "c=����<��/��ɚ�=��=J�w�@�{|=yX->�nL=�X�loq����<gZ=�H>l���6��=[+��<�Ȫ=�\������;�=�M<�Eὁ	����B�<{`:�u>�x��=n<F�F���=��T����=vc=�C���ͽks����2>�]��տ�������=D՘=��K�+>�s=�x���5ý��N�*�F��ì�/�>HzL=�~	���D=#�o=��ս'���1>�">b�b=�� >�Q���?��_�=��2>~�<?Gk=�dB=��<D���!Խ��0�R�>sC�<� ѽ�mB=u(W=ꓦ=G}ӽ�ӽ��=���=�K������&��qC$����=;&��h�=���p\>�N�<bg�����=g�ĽE�ڼ�g>�#�=~������U�=,ة=Ǔ<H1>�[�=ﷂ��A��P���=��%���>���d >�|��j��<��6�O�=r`@=W�!=4e�=�\<t�=���<w+.=�=μ��l�#]=�< >)�v=��=���=7����)νZ��=+8Ǽ�Y��ײ�����(6>��c;��7���=�W<�"�=\���c{=ٴ	��Em��=v[�:#0�'��c7!>��5>�pe;N�����=����3�<,���L�Ͻ�J�=K�4>�pI=)[,��/>�Y��=���F���t��I�=�༂�T���%=ت�<c����=j��=�]$��O�=�۽l��%��=�ż������ ����=��@��;����P�!���=��;>�CɽD�)�+>^F�=$1��u'<!��� >�9�=�I�=L�;�h�=�罋��>��=�w��$��f�<2�<3"�Bn,�dI�4-~�
�����=;h��d��=�+�;ɛ�=@�(>�S~����BH	=�$.��<���0ټ����ﲪ�.�=w3<Pu�=�4���^�=;Q� ?=q�=$7>�L�=�2�=�m�=��=w0�p��:0?ὁ��=@�����jP�<3����>r6ڽO�]�P�H=xZ��H_�=�l�=a� =(��9����ܽ����(>9C�P�<�zҽ&����=�ʼ b-=�>h#�<�$3��{�=؈�<{[>�pn�(���l=���j=ޙ�ފ���������>J���F\�=x�h,d=���?�>"6��(�f�z.�=��=T����<�fV=Wuc�K�o��F�=�J�?�e���</&�-��=�����=\��U罠͐=�|�<|`�� ���%��1>=9'߽ڨ����%=M��<>2������K=|���C� � =��<�m���;�5W��(=6m�=���+<��^|-���=��N�