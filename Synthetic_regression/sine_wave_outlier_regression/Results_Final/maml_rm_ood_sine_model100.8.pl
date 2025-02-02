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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2171089656496qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2171089657360qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2171089657744qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2171089656784q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2171089656592q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2171089656016q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2171089656016qX   2171089656496qX   2171089656592qX   2171089656784qX   2171089657360qX   2171089657744qe.       wǆ�(       ���ǚ;q�=*|н�'�0$�=�;���K1���쾘��aU?|���}��yN?�?m�$yܾX��� �7.?�X0�����s�.�1��%k�f�߾�.^�򡾈U��/���3?};>0!�=�*U?�B���V<�þ�}��i����#?(       �Ӎ>V]7?Ȋ��>-ko��yG?x�;�*M>wZ?*�=�#�=G+x>f�@?=�	<��(�{¾/۽����	.?e{�����='��=6E��R���g3��9�O^��r�ϾkL?>�{>���=��ɾָ=����>~?�0M��,� �<�m��(       ��u�B�7��H����q�]�|�R�����H�c�ۃ����6k��ꄿ�<*=8S?G��>�N�pC׼��j<L��=o�o��54�#"��&�M?��L�l<��vT�y>������<��fl�С3�t�?�7����*?.�˺(:�[fɽݏ?(       X� �:h+>��.>cqd>6�пeY�V'�}�>�Uݿ��F�/�U����n&�Ԗ��*�ܿUHk<��y����>,>���ڿŪ!�)F��4#?��.�>���C���Ao��`�>o��>�+*��=X��>����5�?��?&���5Y>����ƾ@       ~�o7U?�|�?o[4�O	�{��=h��;KP�>N��>K��>�≿�"��c�>��?��DlԾ�>Hlཻ_�>M�Q">�=��'D�&��>���">���=��O>�y9�m�W>�P�������ѫ��d��J7�L'���g>�A���VC>K��=P�b�=����{��<ѣ��
N<�����
彥H��������vaݾ�vѾ�L��m�\�>ad�9�I����>A��(���D���5�0��Ҩ?e5���h=&D���h3<�!M����>Vl(� �s��hU���5�+�$?xz-?���������*˾QY��6#�=�$^?�$��f���%���<aV�<thi��䬾kW`=��=n�I>� ��V����>�����Q��P�>BI�9��=R|)��Z�MN�?+�$������~���˕���;����� �aƽۮ�����U~�:A:�>��p>9�N���a��I_�w���e���"����`�8����=##佐~j�]��X�<@�r;��x=[��.�=��>n1����Ƽר��3ؽ˴�\���X�=��=@&=`	^=����*'�=PϼnV�=3'��`B���f�=�����Ͻj��pѼ1���q>QK=��ǽॳ=V��������:ӽ$~���ʽ_=����<�_Ž�K¼�a�=>��=�(�Y���={�ͽ�0G��`>����P���콡н�c9�do8����!�6�|Lܽ���,�P��<�񑄾@�&���=��Z������r�9`ݽ��v=7i��Խ�=#�@�ݾ]:�>Z��uS�=>]�=�ڸľJe�>m�u>���=��>V�վ�z>�>�?��v���>E�>�O>EVٿ|�p>�X�������>#��>���>�:o>�qf>��[�S�G?;F�2�<?�X>�@��򙈾�h�P+?�u�>��
>x~
=?}Żp۽��/�?'齦P����=��@�z���be�˚�W��K�y�σs= �M�μ�~=���<�;�Re�=`��<�\��<�2��HI�����('<��<��ʽe^�=XB��>~����q�=tн7�7�����ڌ=�Ƚã����2< ��d)>寷?w�-=������=���mT=Y�>�w�=�<<��;q>;�>/}2��mڽ�Y>.���C6>k��?=EC}=�����3\>�i;�>�=�8=Ъc>�(�m#�=����f�	��>���S[��W7�L9��5R|�/ox=��0!���^?>���=��g�ޓ��7�=�;<�B�>[|�;_9�U�q�>8?<�/�^Q�:,�-=P�f��_�v����+=�fL>�WR�q�j=&�����J�r!p�	�<&�d�_�)=��`��>�.�:�B�=�?��3>�Ev������Y���-�==����<	�=�&2�l=@2�p;�<��3<��W�~�p�i�H?���=&�����=���=������3��4��n�=�r�<P�d<��;̽h�}=��>��罥�^������Q�=L��=�=|�=u��<	��]p7�[߽Jf� �= �9N7A�2�=m����F���&�Psx���:hA�P�Z<� �lc	���>���=S>x��<}��� .��H�����=�ښ��O�.��=X����6=NB�=ɩ>�X��Q���o=�)˽��\���k�#h���U��0�M<QCy�-N�  ��`�ý��a2�N���x
?�@�?�;�i�����N=G�(:�>>G�>��/>Ǜ��u��%�>�?�>I
�U�q��=Z>�H8��L\>�i��ހ�=yO5�W&�{�{=���u#>A��BB=�w�=/��>�;�TQ�|�0>N�z���k`� ��>���YG�>l�E�� >�w�?��_?�Z�����=�4�=�
���)3>no�vZ�?�>6����3� [��i>�=���T�_�>��i�<Crt���f>o�C�0���d=��r<}��,\�;.ʽ~�n���n>�M���>I>�E�>�徭Ɋ�o�����q��?f٩�ʿ�;ȏ;�e
�\Ƨ�Y#�=��.��j =�A9<��=�qƽQ"���e=\��;X�����b�>iL򽌕�=��\<6�D=[BF��$�����12�(��}&��b�=�KV��>�&B3�(5�=�W��TG=�?����=>��<ӸS��(���Z��ku>�6�?�#�>4���)�=�љ���:?� �?B��<��q�����==AZ����d�=4��|��=c�9���s�^\��'���h�����=ZG�>N�>��X����>��$?�����]�>[��?�: ��qR��`�_��2W�>�f>>�>�~��1!�������ٿP�Y��f��v��<�㲿�z��ͦ6���&�A�þ�?A�9�M� y��⎾��k��~���>Ѿ ���I���������?�Ҧ��9��Q�ɾp���C&b�ચ�����݆G��M��x>6O�>S/�>6�>I�	�T�8��>����|ؽ����TJ�=�R��!Ͻ��Լ.�)=�1�~_>f[?<S׼q��=��=ȃ��P�+<�����[֟�f�-�c��=T&��v�=w���&���jw=��E��x_=�G�}��q�ڽ�f��`L��z=j$J�[��;5Ύ=����ܽ���ؗT=`$E=�A����$=H�����>c4��(C=��>B)�=Z5�=p�I<(�=v�̵"�Os�@�C�v?�=�\�� @�7HK:==D�X43����-��8Yݽ���\/=��>�;�+6���D��Y�=h�O=\����ʽ(���$�(MW�&��c�T���%M��͊�``Կ'e�=���<��3��Zt��_O<Z�w����e�=��b��5.�Zy�>���W�<�=���)���e��=�O�?��	��8�Kd*>\Fr>*����l;�3���¾�3�<�3O��VϾ��0?�'?XS��0���֖>�k;� bq=�t>žA3=�4�A��UW��=b5���蠽jF��by�C�B�χ=6��=e=]��h* �h����Y�r�?="�ӽ
���q�>�vV=w�侺A���]�Cs*��F�$jh�C�ѽ����W��)��;JZ>v�>ƿ�֗��}�o�)�f�ٽ(@���=9>�Ћ�� >C��M8� ��;�/�=ů!�������#?��ች[��Vм�n<��V� J�=\7=s��&�<#��f��(�<t�x=�s�q��c��{�L<��3��۷����,�=DZp�
��>5�������*��o"�ۙ��D=gY�6�\�mN$<��9=��a���	���X�!m���=�l��^;�,�h�\��H�D��QM���=�P�=A���7��8����Խ�|��q�?���/F��G�s��Z��R�8b�����=ڽr��gZ�^ҽ��k�e���=t ����=�����8�����۽��E��)�=�`D<���Π�=�Xo<��F�(����,��`
��Q� �P=�5�ഽf׾=��==��/��V�<v4�=�i=o����Sd�'��=�����0�'�Ž)Ns=�N�������O=�0=��#����9�T�=q��������%�H�E=V'��je�������{!>������F��v��4fs=��9�i���[нpȿ��<>7ݾ�i�՜��8�<�Vܽ�׶�����(�{�r��=�&��� x�n�b^>Jˁ?yf>s��=�F3=y��<������*>>[�=�6�?Mƈ�`���G~����=d��/�=�5��Ϡ>�`6�ȺA�Q��>���=S㎽j�Ӿ�D�=*� >���>[�����	�<�g?��'������g>Q�o=�/3>Z}�=R�1��s�~��#�4�ƃ�=}K|>9�;��ݾ"廾��>��=����s]�M<�<��x=8�b�n^��'��<n��U�t=W<�ߒ�=���=r5v=�*(�Νr�M��	��}1=�r(=*k���RUP�h����=���� �ͨ�<Tiގ�o���U��n��5ҽ�MY��j�jF��I\E;3��ym���I���%<�о11���N�������=t����΄��P��;�M/�=,γ��=޽}��<��W�CO��;�<m�.�c!k�F%<Y�o=�Դ����ࣥ=:����A<���=��=fb :��8�`���ؖ�T9�=��;J9B�������1�����g���r�=�������k���I� �W	N�GΖ<|Z��!þh���ȗ�����@���i��Z������򬥾;��>�Y�[�¾ؑ������6?�e�/����t���������)"�=�ƾ�!7�a�H�;�<��ߟ<F�l>��.>'�ؾ&��s��Ư�<�=��-�[�4��9��	���zr��D�ʤ���j��m���ܿ�b��%��県�	���J7��@�=�/5�=k߿��-�T����o�?T3�1��T� �G>��J���<�S>5@��כ�#�־A���a�K���*?ZdD?,}{�''��9m���?�+�	�����r��>`����0d<���<k��>T�ʼ���0{a����Y�	<��!�Q�=8,��vD�k�U�H�<���Y>���"��<fD��C��y�<ٳ��zP���ӽƟ�qA�>�RT>R>g�>Ú�>
��S�!�E��<��=v*/��l> �c<8ȴ=t������,l�=.B��ûU�W/�<��,�,f=$��=8�Ƽ��x��ǻ�A����m;G,[��h�=z=㴙;�Ӕ=�)�=��ʽkߦ=����5�ڝ�=)L��d�߽-.�qT��Sn�kp	=����:��*=%=���<�*��s޽��S�W^l���H>�f��˔=(h�=���=�Q�>=$W8=�����=ʡ�οF�`mF>z��#[ �>x�����=C�&>0C7��E���Ȑ��x��~��k3�<S�)��zz=��w��!>n�>��=���>=rj>�VO�}&:��t/��=٤��<����u*��爾�����Њ>]�����<꒾�@�>r��=�
>�D3�~y!=�C�>�7���x��>�憾ۅ\G��>XV����?_E�>*8��4d9����Dy:<��C�Ta���p�Z��=�篿+��!�O���=>�ڄ>H�v�d�$����O½G�9��*"�/E��,��8:�ƶ*��:����>`�k�аýY4��<�]�Al	� >����U�9� >����t��c����=���Y�=���=s���B>O`�¢�=�۴��Ք�
�z�D@����Q?t��>��>��J>`9ܼ�Ǟ�h6�<+�J>3�	��{?D�'?Xz��bƙ���=�=օ>-?�3�>���zW*>���>�V ?���;�m<|K�>V�r�XV�>�(�>U�>5�Ƚa�����>Mjb��+�>̰�=�e>���Q�>≾�<b�>5q<�}u��No�b#�>ښ����>�b�=�C�<���>q3"�e=>�Ḿ'=��B��ὧꢿ򒦿����e���/*��
*�	����=����J���6�=W�����?ыp�e��>��fd��M�W�9n�u����1��	>3c���%���cH?�P?灦�� �=W)���<+����vg��"���U���b>����m�(B�� �<A��F��= ������0� =��� �<�� �)�G����=��.+�=pֵ=}�<|�=��F�h��#�ܽ��?=7о�O '�kM�;D˰��h��e��jT��=��)���=l�'�s�=P׽�h�f<ֽ�Z�� ���(,�Q�f�˓����z,����B�9-��	l�V�e��	��턽JO&��G��pE̽�}���C<�gf����\�1`��n�lfS=�X$����}�r�}8
�w��ʽ~@5����%����!ѽz.��q�=��$���+���1����bu=��.���ڽ���=7|P=��y=�c���&�|r���~�<�H�Go�=f���*<e������Fֽ!
=r��=+J��g��N����콻!='�6���=����<�Of@��i����=8v�
��'��=���<|�J?Rϛ�� �>1����+>�j����>���=��W>�M�Eh�=27�>�r�>#��<����g�=޻�>n�>�z,>���.�齀Rɿ�����>>G?f>��y>���>X>*�>Jn�>�>���>?��!ǧ��i���Er�!>���>�oI�